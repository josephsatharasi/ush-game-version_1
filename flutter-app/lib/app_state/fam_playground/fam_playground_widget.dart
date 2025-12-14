import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'fam_playground_model.dart';
import '../../widgets/loction_header.dart';
import '../../services/game_number_service.dart';
import '../../config/backend_api_config.dart';

class FamPlaygroundWidget extends StatefulWidget {
  const FamPlaygroundWidget({super.key});

  @override
  State<FamPlaygroundWidget> createState() => _FamPlaygroundWidgetState();
}

class _FamPlaygroundWidgetState extends State<FamPlaygroundWidget> {
  final FamPlaygroundModel _model = FamPlaygroundModel();
  String? _gameType;
  bool _initialized = false;
  StreamSubscription? _numberSubscription;
  final Set<int> _blockedNumbers = {};
  bool _firstLineCompleted = false;
  bool _secondLineCompleted = false;
  bool _thirdLineCompleted = false;
  bool _jaldhiCompleted = false;
  bool _housiCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkAndClearOldGameData();
    _loadTicketNumbers();
    _loadMarkedNumbers();
    _numberSubscription = GameNumberService().numberStream.listen((number) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  


  Future<void> _loadTicketNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        final result = await BackendApiConfig.getMyBookings(token: token);
        final bookingsList = result['bookings'] as List;
        
        if (bookingsList.isNotEmpty) {
          final booking = bookingsList.first;
          final generatedNumbers = booking['generatedNumbers'] as List?;
          
          if (generatedNumbers != null && generatedNumbers.isNotEmpty) {
            final firstTicket = generatedNumbers[0] as Map<String, dynamic>;
            final firstLine = (firstTicket['firstLine'] as List?)?.cast<int>() ?? [];
            final secondLine = (firstTicket['secondLine'] as List?)?.cast<int>() ?? [];
            final thirdLine = (firstTicket['thirdLine'] as List?)?.cast<int>() ?? [];
            
            if (mounted) {
              setState(() {
                _model.selectedNumbers.clear();
                _model.selectedNumbers.addAll(firstLine);
                _model.selectedNumbers.addAll(secondLine);
                _model.selectedNumbers.addAll(thirdLine);
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load ticket numbers: $e');
    }
  }
  
  Future<void> _checkAndClearOldGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentGameId = prefs.getString('gameId');
      final savedGameId = prefs.getString('lastMarkedGameId');
      
      if (currentGameId != savedGameId) {
        debugPrint('🆕 New game detected - clearing old marked numbers');
        await prefs.remove('markedNumbers');
        await prefs.setString('lastMarkedGameId', currentGameId ?? '');
      }
    } catch (e) {
      debugPrint('Failed to check game data: $e');
    }
  }
  
  Future<void> _loadMarkedNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final markedList = prefs.getStringList('markedNumbers') ?? [];
      if (mounted) {
        setState(() {
          _blockedNumbers.clear();
          _blockedNumbers.addAll(markedList.map((e) => int.parse(e)));
        });
      }
      debugPrint('💾 Loaded ${_blockedNumbers.length} marked numbers from storage');
    } catch (e) {
      debugPrint('Failed to load marked numbers: $e');
    }
  }
  
  Future<void> _saveMarkedNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('markedNumbers', _blockedNumbers.map((e) => e.toString()).toList());
      debugPrint('💾 Saved ${_blockedNumbers.length} marked numbers to storage');
    } catch (e) {
      debugPrint('Failed to save marked numbers: $e');
    }
  }

  @override
  void dispose() {
    _numberSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _gameType = ModalRoute.of(context)?.settings.arguments as String?;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppHeader(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Go Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'GO BACK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Number Grid Card
                    _buildNumberGridCard(),
                    SizedBox(height: 12),
                    // Game type buttons
                    _buildGameTypeButtons(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGridCard() {
    int start = _model.currentPage * 30 + 1;
    int end = (_model.currentPage + 1) * 30;
    if (end > 90) end = 90;
    
    List<int> numbers = List.generate(end - start + 1, (index) => start + index);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF67002B),
            Color(0xFFCD0056),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Number Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              return _buildNumberButton(numbers[index]);
            },
          ),
          SizedBox(height: 12),
          // Page navigation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFF4A0020),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_model.currentPage > 0) {
                      setState(() {
                        _model.previousPage();
                      });
                    }
                  },
                  child: Icon(Icons.chevron_left, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Text(
                  '$start - $end',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    if (_model.currentPage < _model.totalPages - 1) {
                      setState(() {
                        _model.nextPage();
                      });
                    }
                  },
                  child: Icon(Icons.chevron_right, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    final isAnnounced = GameNumberService().announcedNumbers.contains(number);
    final isTicketNumber = _model.isNumberSelected(number);
    final isClicked = _blockedNumbers.contains(number);
    
    return GestureDetector(
      onTap: (isTicketNumber && isAnnounced) ? () {
        setState(() {
          if (_blockedNumbers.contains(number)) {
            _blockedNumbers.remove(number);
          } else {
            _blockedNumbers.add(number);
          }
        });
        _saveMarkedNumbers();
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: isClicked ? Color(0xFFE91E63) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isClicked ? Color(0xFFE91E63) : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isClicked ? Colors.white : Color(0xFFE91E63),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTypeButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGameButton('FIRST LINE', Color(0xFF1E40AF), '1'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildGameButton('SECOND LINE', Color(0xFFDC2626), '2'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildGameButton('THIRD LINE', Color(0xFF059669), '3'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildGameButton('JALDHI', Color(0xFFF59E0B), '5'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildGameButton('HOUSI', Color(0xFF9F1239), null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameButton(String name, Color color, String? number) {
    bool isCompleted = false;
    
    switch (name) {
      case 'FIRST LINE':
        isCompleted = _firstLineCompleted;
        break;
      case 'SECOND LINE':
        isCompleted = _secondLineCompleted;
        break;
      case 'THIRD LINE':
        isCompleted = _thirdLineCompleted;
        break;
      case 'JALDHI':
        isCompleted = _jaldhiCompleted;
        break;
      case 'HOUSI':
        isCompleted = _housiCompleted;
        break;
    }
    
    return GestureDetector(
      onTap: () async {
        await _handleLineButtonTap(name);
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey : color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.check_circle, color: Colors.white, size: 18),
                    ),
                ],
              ),
            ),
            if (number != null)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleLineButtonTap(String lineType) async {
    // Check if already claimed
    bool alreadyClaimed = false;
    switch (lineType) {
      case 'FIRST LINE':
        alreadyClaimed = _firstLineCompleted;
        break;
      case 'SECOND LINE':
        alreadyClaimed = _secondLineCompleted;
        break;
      case 'THIRD LINE':
        alreadyClaimed = _thirdLineCompleted;
        break;
      case 'JALDHI':
        alreadyClaimed = _jaldhiCompleted;
        break;
      case 'HOUSI':
        alreadyClaimed = _housiCompleted;
        break;
    }
    
    if (alreadyClaimed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$lineType already claimed!'), backgroundColor: Colors.grey, duration: Duration(seconds: 2)),
        );
      }
      return;
    }
    
    // Get line numbers from ticket
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    
    // Load ticket to get line numbers
    List<int> lineNumbers = [];
    try {
      final result = await BackendApiConfig.getMyBookings(token: token);
      final bookingsList = result['bookings'] as List;
      
      if (bookingsList.isNotEmpty) {
        final booking = bookingsList.first;
        final generatedNumbers = booking['generatedNumbers'] as List?;
        
        if (generatedNumbers != null && generatedNumbers.isNotEmpty) {
          final firstTicket = generatedNumbers[0] as Map<String, dynamic>;
          final firstLine = (firstTicket['firstLine'] as List?)?.cast<int>() ?? [];
          final secondLine = (firstTicket['secondLine'] as List?)?.cast<int>() ?? [];
          final thirdLine = (firstTicket['thirdLine'] as List?)?.cast<int>() ?? [];
          
          switch (lineType) {
            case 'FIRST LINE':
              lineNumbers = firstLine;
              break;
            case 'SECOND LINE':
              lineNumbers = secondLine;
              break;
            case 'THIRD LINE':
              lineNumbers = thirdLine;
              break;
            case 'JALDHI':
            case 'HOUSI':
              lineNumbers = [...firstLine, ...secondLine, ...thirdLine];
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load ticket: $e');
    }
    
    if (lineNumbers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ticket numbers'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    
    // Validate: all line numbers must be announced AND marked
    final announcedNumbers = GameNumberService().announcedNumbers;
    bool allAnnounced = lineNumbers.every((num) => announcedNumbers.contains(num));
    bool allMarked = lineNumbers.every((num) => _blockedNumbers.contains(num));
    
    if (!allAnnounced) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$lineType not completed yet! Wait for all numbers.'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
        );
      }
      return;
    }
    
    if (!allMarked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please mark all numbers first!'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
        );
      }
      return;
    }
    
    final gameId = prefs.getString('gameId');
    final cardNumber = prefs.getString('cardNumber');
    
    if (token == null || gameId == null || cardNumber == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing credentials'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    
    final winTypeMap = {
      'FIRST LINE': 'FIRST_LINE',
      'SECOND LINE': 'SECOND_LINE',
      'THIRD LINE': 'THIRD_LINE',
      'JALDHI': 'JALDI',
      'HOUSI': 'HOUSIE',
    };
    
    try {
      final response = await BackendApiConfig.claimWin(
        token: token,
        gameId: gameId,
        winType: winTypeMap[lineType]!,
        cardNumber: cardNumber,
      );
      
      // Save coupon data from response
      if (response['couponCode'] != null) {
        await prefs.setString('wonCouponCode', response['couponCode']);
        await prefs.setInt('wonCouponValue', response['couponValue'] ?? 0);
        debugPrint('🎟️ Coupon saved: ${response['couponCode']} - ₹${response['couponValue']}');
      }
      
      if (mounted) {
        setState(() {
          switch (lineType) {
            case 'FIRST LINE':
              _firstLineCompleted = true;
              prefs.setBool('firstLineCompleted', true);
              break;
            case 'SECOND LINE':
              _secondLineCompleted = true;
              prefs.setBool('secondLineCompleted', true);
              break;
            case 'THIRD LINE':
              _thirdLineCompleted = true;
              prefs.setBool('thirdLineCompleted', true);
              break;
            case 'JALDHI':
              _jaldhiCompleted = true;
              prefs.setBool('jaldhiCompleted', true);
              break;
            case 'HOUSI':
              _housiCompleted = true;
              prefs.setBool('housiCompleted', true);
              break;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 $lineType claimed successfully!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );
        
        // Navigate to winner screen after ANY win
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/winner');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
