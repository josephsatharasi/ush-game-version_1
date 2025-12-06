import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'live_gametype1_model.dart';
import '../../widgets/loction_header.dart';
import '../../widgets/order_successful.dart';
import '../../services/background_music_service.dart';
import '../../services/game_service.dart';
import '../../config/backend_api_config.dart';

class LiveGametype1Widget extends StatefulWidget {
  const LiveGametype1Widget({super.key});

  @override
  State<LiveGametype1Widget> createState() => _LiveGametype1WidgetState();
}

class _LiveGametype1WidgetState extends State<LiveGametype1Widget> {
  final LiveGametype1Model _model = LiveGametype1Model();
  bool _showCustomTicketPopup = false;
  bool _isLoading = false;
  String? _gameId;
  String? _gameStatus;

  @override
  void initState() {
    super.initState();
    BackgroundMusicService().play();
    _loadLiveGame();
    _listenToGameStatus();
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

  Future<void> _loadLiveGame() async {
    try {
      final response = await BackendApiConfig.getLiveGame();
      if (mounted) {
        setState(() {
          _gameId = response['game']['_id'];
        });
      }
    } catch (e) {
      // Backend not available, use mock game ID for local testing
      if (mounted) {
        setState(() {
          _gameId = 'mock-game-id';
        });
      }
    }
  }

  Future<void> _bookTicket() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_gameId != null && _gameId != 'mock-game-id') {
        final token = prefs.getString('token');
        if (token != null) {
          try {
            final response = await BackendApiConfig.bookTicket(
              token: token,
              gameId: _gameId!,
            );
            await prefs.setString('cardNumber', response['booking']['cardNumber']);
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
      body: Stack(
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
                              onTap: () => Navigator.pop(context),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, size: 20),
                                  SizedBox(width: 4),
                                  Text('Back',
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
      ),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Table(
                  border: TableBorder.all(color: Colors.grey[400]!, width: 1),
                  children: _model.ticketData.map((row) {
                    return TableRow(
                      children: row.map((cell) {
                        final bool isBlue = _model.blueCells.contains(cell);
                        final bool isEmpty = cell.isEmpty;
                        return Container(
                          height: 45,
                          color: isBlue
                              ? Color(0xFF3B82F6)
                              : isEmpty
                                  ? Colors.grey[100]
                                  : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            cell,
                            style: TextStyle(
                              color: isBlue ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (index < count - 1)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                height: 6,
                color: Colors.black,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNumberCapsule() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNumber("2"),
          _buildDivider(),
          _buildNumber("4"),
          _buildDivider(),
          _buildNumber("5"),
        ],
      ),
    );
  }

  Widget _buildNumber(String num) {
    final value = int.parse(num);
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.setCustomTicketCount(value);
          _model.selectTicketType('Custom Tickets');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Tickets',
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
        Row(
          children: [
            Expanded(child: _buildTicketButton('1 Ticket')),
            SizedBox(width: 12),
            Expanded(child: _buildTicketButton('3 Ticket')),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTicketButton('6 Ticket')),
            SizedBox(width: 12),
            Expanded(
                child: _buildTicketButton('Custom Tickets', hasIcon: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketButton(String type, {bool hasIcon = false}) {
    final isSelected = _model.selectedTicketType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.selectTicketType(type);
        });
        // Show popup only for Custom Tickets
        if (type == 'Custom Tickets') {
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
    if (_model.selectedWeekDay != -1 && _model.selectedTimeSlot != null) {
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
                  Text('August',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildWeekDaySelector(),
        // SizedBox(height: 8),
        _buildTimeSlotGrid(),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_model.weekDays.length, (index) {
          final isSelected = _model.selectedWeekDay == index;
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
                width: 50,
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: isSelected
                    ? BoxDecoration(
                        color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(30),
                      )
                    : BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.grey.shade600,
                          width: 2,
                        ),
                      ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day label (only show when selected)
                    isSelected
                        ? Text(
                            _model.weekDays[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          )
                        : const SizedBox(height: 10),
                    // Divider line
                    Container(
                      width: 18,
                      height: 1.5,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    // Date number
                    isSelected
                        ? Text(
                            _model.weekNumbers[index].toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E3A8A),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _model.weekNumbers[index].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
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
