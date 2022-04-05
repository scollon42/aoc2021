
static int PartOne(string[] inputs)
{
  int horizontal = 0;
  int depth = 0;

  foreach (string line in inputs)
  {
    string[] instructions = line.Trim().Split(" ");

    int value = int.Parse(instructions[1]);

    switch (instructions[0])
    {
      case "forward": horizontal += value; break;
      case "down": depth += value; break;
      case "up": depth -= value; break;
      default: break;
    }
  }

  return horizontal * depth;
}


static int PartTwo(string[] inputs)
{
  int horizontal = 0;
  int depth = 0;
  int aim = 0;

  foreach (string line in inputs)
  {
    string[] instructions = line.Trim().Split(" ");

    int value = int.Parse(instructions[1]);

    switch (instructions[0])
    {
      case "forward":
        horizontal += value;
        depth += (value * aim);
        break;
      case "down": aim += value; break;
      case "up": aim -= value; break;
      default: break;
    }
  }

  return horizontal * depth;
}

string[] inputs = System.IO.File.ReadAllLines("input");

Console.WriteLine($"Part 1 = [{PartOne(inputs)}]");
Console.WriteLine($"Part 2 = [{PartTwo(inputs)}]");
