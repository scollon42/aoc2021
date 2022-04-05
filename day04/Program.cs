using System;
using System.Collections.Generic;
using System.Linq;

using day04;

IEnumerable<int> GetNumbers(IEnumerable<string> lines)
{
    return lines.First().Trim().Split(",").Select(int.Parse);
}

IEnumerable<Board> GetBoards(IEnumerable<string> lines)
{
    return lines
        .Skip(1)
        .Where(str => str.Trim() != "")
        .Chunk(5)
        .Select(chunk =>
            chunk.SelectMany(e =>
                e.Trim().Split(" ", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse)
            )
        )
        .Select(chunk => new Board(chunk));
}

void Main()
{
    var lines = System.IO.File.ReadAllLines("input");

    var numbers = GetNumbers(lines);
    var boards = GetBoards(lines).ToList();

    var winnerIndex = 0;
    
    foreach (var number in numbers)
    {
        foreach (var board in boards.Where(board => !board.Won))
        {
            board.MarkNumber(number);

            if (board.HasWon())
                board.SetAsWinner(++winnerIndex, number);
        }
    }

    var scoreboard = boards.OrderBy(board => board.Position).ToList();

    Console.WriteLine($"Part1 Score = {scoreboard.First().Score()}");
    Console.WriteLine($"Part2 Score = {scoreboard.Last().Score()}");
}

Main();
