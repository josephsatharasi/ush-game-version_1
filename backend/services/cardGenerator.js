class CardGenerator {
  generateCardNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  generateTicketNumbers() {
    const allNumbers = new Set();
    while (allNumbers.size < 15) {
      const num = Math.floor(Math.random() * 90) + 1;
      allNumbers.add(num);
    }
    
    const sortedNumbers = Array.from(allNumbers).sort((a, b) => a - b);
    
    return {
      firstLine: sortedNumbers.slice(0, 5),
      secondLine: sortedNumbers.slice(5, 10),
      thirdLine: sortedNumbers.slice(10, 15)
    };
  }
}

module.exports = new CardGenerator();
