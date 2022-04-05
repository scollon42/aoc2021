using System;
using System.Collections.Generic;
using System.Linq;

namespace day04
{
    public class Board
    {
        private const int RowSize = 5;
        public int Position { get; private set; }
        public bool Won { get; private set; }
        private int WinningNumber { get; set; }

        private List<int> _numbers;

        public Board(IEnumerable<int> numbers)
        {
            _numbers = new List<int>(numbers);
            Won = false;
            WinningNumber = -1;
            Position = -1;
        }

        public int Score() => Sum() * WinningNumber;

        private int Sum() => _numbers.Where(number => number != -1).Sum();

        public void MarkNumber(int number) => _numbers = _numbers.Select(n => n == number ? -1 : n).ToList();

        public void SetAsWinner(int position, int winningNumber)
        {
            Position = position;
            WinningNumber = winningNumber;
            Won = true;
        }

        public bool HasWon() => RowWin() || ColWin();
        private bool RowWin() => _numbers.Chunk(RowSize).Any(line => line.All(e => e == -1));

        private bool ColWin() =>
            _numbers.Select((number, index) => (number, index))
                .GroupBy(value => value.index % RowSize)
                .Any(col => col.All(e => e.number == -1));
    }
}