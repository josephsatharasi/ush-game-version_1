import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'live_gametype1_model.dart';
import '../../widgets/loction_header.dart';
import '../../widgets/order_successful.dart';
import '../../services/background_music_service.dart';
import '../../services/game_service.dart';
import '../../config/backend_api_config.dart';

class LiveGametype1Widget extends StatefulWidget {
  final String? gameId;
  
  const LiveGametype1Widget({super.key, this.gameId});

  @override
  State<LiveGametype1Widget> createState() => _LiveGametype1WidgetState();
}

class _LiveGametype1WidgetState extends State<LiveGametype1Widget> {
  final LiveGametype1Model _model = LiveGametype1Model();
  bool _showCustomTicketPopup = false;
  bool _isLoading = false;
  String? _gameId;
  String? _gameStatus;
  List<Map<String, dynamic>> _availableGames = [];
  bool _showGameSelection = true;
  Map<String, dynamic>? _selectedGame;

  @override
  void initState() {
    super.initState();
    BackgroundMusicService().play();
    _listenToGameStatus();
    
    if (widget.gameId != null) {
      _gameId = widget.gameId;
      _showGameSelection = false;
      _loadSlotConfiguration(widget.gameId!);
    } else {
      _loadAvailableGames();
    }
  }

  void _listenToGameStatus() {
    GameService().gameStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _gameStatus = status['status'];
        });
      }
    });
  }

  Future<void> _loadAvailableGames() async {
    try {
      final response = await BackendApiConfig.getAllGames();
      if (mounted) {
        setState(() {
          _availableGames = List<Map<String, dynamic>>.from(response['games'] ?? [])
              .where((game) => game['status'] == 'LIVE' || game['status'] == 'SCHEDULED')
              .toList();
        });
      }
    } catch (e) {
      print('Error loading games: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load games: $e')),
        );
      }
    }
  }

  void _selectGame(Map<String, dynamic> game) {
    setState(() {
      _selectedGame = game;
      _gameId = game['_id'];
      _showGameSelection = false;
    });
    _loadSlotConfiguration(game['_id']);
  }

  Future<void> _loadSlotConfiguration(String gameId) async {
    try {
      final response = await BackendApiConfig.getGameSlotConfig(gameId: gameId);
      if (mounted) {
        setState(() {
          _model.updateSlotConfiguration(response['config']);
        });
      }
    } catch (e) {
      print('Using default slot configuration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No slot configuration found for this game')),
        );
      }
    }
  }

  Future<void> _bookTicket() async {
    if (!_model.canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a day and time slot')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_gameId != null && _gameId != 'mock-game-id') {
        final token = prefs.getString('token');
        if (token != null) {
          try {
            if (_model.weekDays.isEmpty || _model.selectedWeekDay >= _model.weekDays.length) {
              throw Exception('Invalid day selection');
            }
            
            final scheduledDate = DateTime.now().add(Duration(days: 1)).toIso8601String();
            final weekDay = _model.weekDays[_model.selectedWeekDay];
            final timeSlot = _model.selectedTimeSlot!;
            
            final response = await BackendApiConfig.bookTicket(
              token: token,
              gameId: _gameId!,
              ticketCount: _model.currentTicketCount,
              scheduledDate: scheduledDate,
              weekDay: weekDay,
              timeSlot: timeSlot,
            );
            
            await prefs.setString('cardNumbers', response['booking']['cardNumbers'].join(','));
            await prefs.setString('bookingId', response['booking']['_id']);
            await prefs.setString('gameId', _gameId!);
            
            if (mounted) {
              GameService().startPolling();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderSuccessful(),
                ),
              );
            }
            return;
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() => _isLoading = false);
            return;
          }
        }
      }
      
      await _createMockBooking(prefs);
      if (mounted) {
        GameService().startPolling();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderSuccessful(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createMockBooking(SharedPreferences prefs) async {
    final mockCardNumber = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    await prefs.setString('cardNumber', mockCardNumber);
    await prefs.setString('bookingId', 'mock-booking-${mockCardNumber}');
  }

  @override
  void dispose() {
    GameService().stopPolling();
    super.dispose();
  }

  void _showCustomTicketDialog() {
    setState(() {
      _showCustomTicketPopup = true;
    });
  }

  void _hideCustomTicketDialog() {
    setState(() {
      _showCustomTicketPopup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showGameSelection ? _buildGameSelection() : _buildTicketBooking(),
    );
  }

  Widget _buildGameSelection() {
    return Column(
      children: [
        AppHeader(),
        Expanded(
          child: _availableGames.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading available games...'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _availableGames.length,
                  itemBuilder: (context, index) {
                    return _buildGameCard(_availableGames[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final gameCode = game['gameCode'] ?? 'Unknown';
    final status = game['status'] ?? 'SCHEDULED';
    final scheduledTime = DateTime.tryParse(game['scheduledTime'] ?? '');
    final totalSlots = game['totalSlots'] ?? 0;
    final bookedSlots = game['bookedSlots'] ?? 0;
    final availableSlots = totalSlots - bookedSlots;

    Color statusColor = Colors.orange;
    if (status == 'LIVE') statusColor = Colors.green;
    if (status == 'COMPLETED') statusColor = Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: status == 'COMPLETED' ? null : () => _selectGame(game),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    gameCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (scheduledTime != null)
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year} at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '$availableSlots/$totalSlots slots available',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: status == 'COMPLETED' ? null : () => _selectGame(game),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF1E3A8A),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    status == 'COMPLETED' ? 'Game Ended' : 'Join Game',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketBooking() {
    return Stack(
      children: [
        Column(
          children: [
            // Header
            AppHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Back and Share buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_showGameSelection) {
                                  Navigator.pop(context);
                                } else {
                                  setState(() {
                                    _showGameSelection = true;
                                    _selectedGame = null;
                                    _gameId = null;
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, size: 20),
                                  SizedBox(width: 4),
                                  Text(_showGameSelection ? 'Back' : 'Games',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Text('Share',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(width: 4),
                                  Icon(Icons.share,
                                      color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Game Info
                        if (_selectedGame != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedGame!['gameCode'] ?? 'Game',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.people, color: Colors.white70, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      '${(_selectedGame!['totalSlots'] ?? 0) - (_selectedGame!['bookedSlots'] ?? 0)} slots available',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        // Game Status & Numbers Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_gameStatus != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _gameStatus == 'LIVE' ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _gameStatus!,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/fam-playground', arguments: 'HOUSI');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Text(
                                  'Numbers',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Number Grid
                        _buildTicketsHeader(),
                        SizedBox(height: 8),
                        _buildNumberGrid(),
                        SizedBox(height: 12),
                        Text(
                          'Note: The number pattern is different from the Original Ticket is delivered to you!!',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 24),
                        // Select Tickets
                        _buildTicketSelection(),
                        SizedBox(height: 24),
                        // Time Slots
                        _buildTimeSlotsSection(),
                        // SizedBox(height: 24),
                        // Order Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_model.canProceed && !_isLoading) ? _bookTicket : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E3A8A),
                              disabledBackgroundColor: Color(0xFF1E3A8A),
                              disabledForegroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              _orderButtonLabel(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Custom Ticket Popup Overlay
          if (_showCustomTicketPopup)
            GestureDetector(
              onTap: _hideCustomTicketDialog,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping the popup
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select Number of Tickets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 24),
                        _buildNumberCapsule(),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    
  }

  Widget _buildTicketsHeader() {
    final count = _model.currentTicketCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          count == 1 ? '1 Ticket' : '$count Tickets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildNumberGrid() {
    final count = _model.currentTicketCount;
    return Column(
      children: List.generate(count, (index) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Ticket ${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambola ticket will be generated after booking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (index < count - 1)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                height: 2,
                color: Colors.grey[300],
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNumberCapsule() {
    final maxTickets = _model.maxTicketsPerUser;
    List<Widget> numbers = [];
    
    // Generate numbers based on maxTicketsPerUser
    List<int> availableNumbers = [];
    if (maxTickets >= 2) availableNumbers.add(2);
    if (maxTickets >= 4) availableNumbers.add(4);
    if (maxTickets >= 5) availableNumbers.add(5);
    if (maxTickets == 6) availableNumbers.add(6);
    
    // If no predefined numbers, show 2 and maxTickets
    if (availableNumbers.isEmpty) {
      availableNumbers = [2, maxTickets].where((n) => n <= maxTickets).toSet().toList();
    }
    
    for (int i = 0; i < availableNumbers.length; i++) {
      if (i > 0) numbers.add(_buildDivider());
      numbers.add(_buildNumber(availableNumbers[i].toString()));
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: numbers,
      ),
    );
  }

  Widget _buildNumber(String num) {
    final value = int.parse(num);
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.setCustomTicketCount(value);
          _model.selectTicketType('Custom');
          _hideCustomTicketDialog();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          num,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.5,
      height: 35,
      color: Colors.white.withValues(alpha: 0.4),
    );
  }

  Widget _buildGreenCapsule() {
    return Container(
      width: 65,
      height: 18,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D8A3A), // light green
            Color(0xFF005C22), // dark green
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left small bump
          Positioned(
            left: -8,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                color: Color(0xFF005C22),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right small bump
          Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Container(
              width: 16,
              decoration: BoxDecoration(
                color: Color(0xFF005C22),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // White text
          Center(
            child: Text(
              'Best time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelection() {
    if (_model.ticketTypes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading ticket options...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Tickets (Max: ${_model.maxTicketsPerUser})',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text('Free',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildDynamicTicketButtons(),
      ],
    );
  }

  Widget _buildDynamicTicketButtons() {
    final ticketTypes = _model.ticketTypes;
    if (ticketTypes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Text('Loading ticket options...', 
                   style: TextStyle(color: Colors.grey)),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < ticketTypes.length; i += 2) {
      List<Widget> rowChildren = [];
      
      // First button in row
      rowChildren.add(Expanded(
        child: _buildTicketButton(
          ticketTypes[i], 
          hasIcon: ticketTypes[i] == 'Custom'
        )
      ));
      
      // Second button in row (if exists)
      if (i + 1 < ticketTypes.length) {
        rowChildren.add(SizedBox(width: 12));
        rowChildren.add(Expanded(
          child: _buildTicketButton(
            ticketTypes[i + 1], 
            hasIcon: ticketTypes[i + 1] == 'Custom'
          )
        ));
      }
      
      rows.add(Row(children: rowChildren));
      if (i + 2 < ticketTypes.length) {
        rows.add(SizedBox(height: 12));
      }
    }
    
    return Column(children: rows);
  }

  Widget _buildTicketButton(String type, {bool hasIcon = false}) {
    final isSelected = _model.selectedTicketType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.selectTicketType(type);
        });
        // Show popup only for Custom
        if (type == 'Custom') {
          _showCustomTicketDialog();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Color(0xFF1E3A8A) : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Center(
          child: hasIcon
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Color(0xFF1E3A8A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: isSelected ? Color(0xFF1E3A8A) : Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                )
              : Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }

  String _orderButtonLabel() {
    final count = _model.currentTicketCount;
    final ticketText = count == 1 ? '1 ticket' : '$count tickets';
    if (_model.selectedWeekDay != -1 && 
        _model.selectedTimeSlot != null && 
        _model.weekDays.isNotEmpty &&
        _model.selectedWeekDay < _model.weekDays.length) {
      final day = _model.weekDays[_model.selectedWeekDay];
      final time = _model.selectedTimeSlot!;
      return 'Order $ticketText · $day · $time';
    }
    return 'Order $ticketText';
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Time Slot's",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Text('Available Days: ${_model.weekDays.length}',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.calendar_today, size: 16),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildWeekDaySelector(),
        SizedBox(height: 16),
        _buildTimeSlotGrid(),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    if (_model.weekDays.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Text(
          'No available days configured',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_model.weekDays.length, (index) {
          final isSelected = _model.selectedWeekDay == index;
          final dayNumber = DateTime.now().add(Duration(days: index + 1)).day;
          
          return Padding(
            padding: EdgeInsets.only(
                right: index < _model.weekDays.length - 1 ? 16 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _model.selectWeekDay(index);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: isSelected
                    ? BoxDecoration(
                        color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(16),
                      )
                    : BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _model.weekDays[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    if (_model.timeSlots.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No time slots configured',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            Text(
              'Admin needs to configure time slots for this game',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
      ),
      itemCount: _model.timeSlots.length,
      itemBuilder: (context, index) {
        final slot = _model.timeSlots[index];
        return _buildTimeSlotCard(
          slot['time'],
          slot['slots'],
          slot['badge'],
        );
      },
    );
  }

  Widget _buildTimeSlotCard(String time, int slots, String? badge) {
    final isSelected = _model.selectedTimeSlot == time;

    Color badgeColor = Color(0xFF10B981);
    if (badge == 'Low Time') badgeColor = Color(0xFFEF4444);
    if (badge == 'Good time') badgeColor = Color(0xFFFFA500);

    return GestureDetector(
      onTap: () {
        setState(() {
          _model.selectTimeSlot(time);
        });
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 78),
        padding: EdgeInsets.fromLTRB(14, 14, 14, 24),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF1E3A8A) : Colors.black,
            width: 2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '$slots Slots left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Color.fromARGB(255, 3, 2, 2),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            if (badge != null && !isSelected)
              Positioned(
                right: 0,
                bottom: -45,
                child: badge == 'Best time'
                    ? _buildGreenCapsule()
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
