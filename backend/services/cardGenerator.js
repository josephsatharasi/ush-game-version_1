class CardGenerator {
  generateCardNumber() {
    return Math.floor(10000 + Math.random() * 90000).toString();
  }

  generateTicketNumbers() {
    const numbers = new Set();
    while (numbers.size < 15) {
      const num = Math.floor(Math.random() * 90) + 1;
      numbers.add(num);
    }
    return Array.from(numbers).sort((a, b) => a - b).join(',');
  }
}

module.exports = new CardGenerator();
