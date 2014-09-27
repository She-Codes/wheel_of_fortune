require 'pry'
class Wheel
  attr_accessor :prizes

  def initialize
    @prizes = ['bankruptcy', 300, 350, 400, 450, 'new car', 500, 600, 650, 700, 'island vacation', 1000, 'bankruptcy']
  end

  def spin
    prize_number = rand(prizes.length)
    prizes[prize_number]
  end
end


class Board
  attr_accessor :puzzles, :guessed_letters, :active_puzzle, :vowels

  def initialize
    @puzzles = [["Movie", "THE TALENTED MR. RIPLEY"], ["Fictional Characters", "FIONA AND CAKE"], ["Thing", "APPLE ORCHARD"], 
      ["Thing", "FATHERHOOD"], ["People", "ENTHUSIASTIC SUPPORTERS"], ["Phrase", "EVERY DAY FEELS LIKE SATURDAY"], 
      ["Tv Title", "GOOD MORNING AMERICA"], ["What Are You Doing?", "SITTING ON THE FRONT PORCH"], ["Landmark", "MONUMENT VALLEY"],
      ["Same Name", "FLORIDA AND CAR KEYS"]]
    @vowels = ["A","E","I","O","U"]
    @guessed_letters = []
  end

  def pick_puzzle!
    puzzle_number = rand(@puzzles.length)
    @puzzles.delete_at(puzzle_number) #returns element that is deleted
  end

  def show_puzzle(puzzle)
    phrase = puzzle[1]
    slots_arr = phrase.chars.map! {|c|
              if ('A'..'Z').include?(c) && !guessed_letters.include?(c)
                '_|'
              else
                "#{c}|"
              end
            }
    slots = slots_arr.join.gsub(/\s/, '   ')
    slots.prepend('|')    

    slots
  end

  def clue(puzzle)
    puzzle[0]
  end

end


class Player
  attr_accessor :name, :account

  def initialize(name="Player")
    @name = name
    @account = []
  end

  def get_money
    money = []
    sum = 0
    account.each {|prize|
      money << prize if prize.to_i != 0
    }
    money.each {|num|
      sum += num
    }

    sum
  end

  def get_things
    things = []
    account.each {|thing|
      things << thing if thing.to_i == 0
    }
    things
  end
end

class WheelOfFortune
  attr_accessor :player, :wheel, :board, :player_insults, :round

  def initialize
    @player = Player.new
    @wheel = Wheel.new
    @board = Board.new
    @player_insults = ["wise guy", "smarty pants", "know-it-all"]
    @round = 1
  end

  def welcome_player
    puts "Welcome to Wheel of Fortune Lite!"
    puts
    puts "This is a simplified version of the popular game show 'Wheel of Fortune'."
    puts "In order to win money, just spin the wheel.  If the wheel lands on a dollar value, guess a consonant."  
    puts "If it's in the puzzle, you win the amount of the spin multiplied by the number of times the letter "\
         "appears in the puzzle."
    puts "If you miss, you lose the amount of your spin."
    puts "In order to add a vowel to the puzzle you must pay a flat fee of $250 no matter "\
         "how many vowels there are."
    puts
    puts "You do not receive your winnings unless you correctly "\
         "guess the puzzle."
    puts
    puts "Ready?  Let's play!"
  end

  def get_player_name
    puts "What's your name?"
    player.name = gets.chomp
  end

  def put_puzzle_on_board(board, puzzle)
    puts "Let's put the puzzle on the board!'"
    puts
    puts board.show_puzzle(puzzle)
    puts
    puts board.clue(puzzle)
  end

  def player_spin
    puts "Press 'enter' to take a spin:"
    spin_answer = gets.chomp

    while !spin_answer.empty? && spin_answer != 'exit'
      puts "Press 'enter' to take a spin:"
      spin_answer = gets.chomp
    end

    if spin_answer.empty?
      wheel.spin
    elsif spin_answer == 'exit'
      exit
    end
  end

  def player_choice
    puts "Please enter 'g' to guess a letter or 's' to solve the puzzle."
    choice = gets.chomp
    choices = ["g", "s", "exit"]

    while !choices.include?(choice)
      puts "Please enter 'g' to guess a letter or 's' to solve the puzzle."
      choice = gets.chomp
    end

    choice
  end

  def guess_letter(board)
    puts "Please enter your letter.  Remember if your letter is a vowel it will cost you $250!"
    letter = gets.chomp.upcase
    
    while true
      if letter.length > 1
        puts "Please guess only 1 letter."
        letter = gets.chomp.upcase
      elsif board.guessed_letters.include?(letter)
        puts "That letter has already been guessed.  Please select a new letter."
        letter = gets.chomp.upcase
      elsif board.vowels.include?(letter)
        if player.get_money < 250
          puts "Sorry, you don't have enough money in your account to buy a vowel.  Please guess a new letter."
          letter = gets.chomp.upcase
        else
          player.account << -250
          puts "You just bought the letter #{letter}."
          break
        end
      else
        break
      end
    end
    board.guessed_letters << letter
    letter
  end

  def letter_on_board?(letter, puzzle) #returns the number of times letter occurs in puzzle
    puzzle[1].count(letter)
  end

  def adjust_account(prize)
    player.account << prize
  end

  def solve_puzzle
    puts "So you'd like to solve - what is your answer?"
    answer = gets.chomp
  end

  def play_next_round?
    answers = ['y', 'n']
    puts "Would you like to play Round #{round + 1}?  Enter 'y' for YES and 'n' for NO."
    answer = gets.chomp

    while !answers.include?(answer)
      puts "Please enter 'y' or 'n'"
      answer = gets.chomp
    end

    answer
  end

  def get_total

  end

  def get_score

  end

  def take_turn(puzzle)
    prize = player_spin #should return a prize or exit game
    
    puts "You've landed on #{prize}."
    if prize == 'bankruptcy'
      player.account = []
      puts "I'm sorry your account is now at $0.00"
      return true
    else
      choice = player_choice

      if choice == 'g'
        letter = guess_letter(board)
        letter_occurences = letter_on_board?(letter, puzzle)
        if letter_occurences > 0
          puts "We have #{letter_occurences} #{letter}#{"'s" if letter_occurences > 1}"
          if prize.to_i != 0
            prize *= letter_occurences
            puts "That's $#{prize}!"
          else
            puts "You got the #{prize}!"
          end
          adjust_account(prize)

          puts
          puts "Your account:"
          puts "#{player.get_money}"
          if !player.get_things.empty?
            player.get_things.each {|thing|
              puts "#{thing}"
            }
          end

          if !board.show_puzzle(puzzle).include?('_')
            puts "Congratulations! It looks like you've solved the puzzle!"
            puts
            puts "You've won:"
            puts player.get_money
            puts player.get_things
            return false
          else
            return true
          end
        elsif letter_occurences == 0
          puts "Sorry there are no #{letter}'s."

          puts
          puts "Your account:"
          puts "#{player.get_money}"
          if !player.get_things.empty?
            player.get_things.each {|thing|
              puts "#{thing}"
            }
          end
          return true
        end
      elsif choice == 's'
        player_answer = solve_puzzle
        if player_answer == puzzle[1]
          adjust_account(prize)
          puts "You are correct! You've won this round!"
          puts "Puzzle:"
          puts puzzle[1]
          puts
          puts "You've won:"
          puts player.get_money
          puts player.get_things
          return false
        else
          player.account = []
          puts "I'm sorry that is incorrect.  The correct answer was......"
          puts "Puzzle:"
          puts puzzle[1]
          puts
          puts "I'm sorry but you lose.  GAME OVER."
          return false
        end
      elsif choice == 'exit'
        exit
      end
    end
  end

  def play
    welcome_player

    player.name = get_player_name

    puts "Hi #{player.name}!"

    while round < 3
      if round == 3
        puts "Let's start the final round!"
      else
        puts "Let's start ROUND #{round}!"
      end
      puzzle = board.pick_puzzle!
      board.guessed_letters = []

      put_puzzle_on_board(board, puzzle)

      while true
        if take_turn(puzzle) == false
          break
        else
          puts board.show_puzzle(puzzle)
          puts
          puts board.clue(puzzle)
        end
      end

      #need to put some condition here if person just wants to quit and not be asked to play another round.
      
      if player.account == []
        answers =['y', 'n'] 
        puts "Play again? Please enter 'y' or 'n'."
        answer = gets.chomp
        while !answers.include?(answer)
          puts "Please answer 'y' or 'n'."
          answer = gets.chomp
        end

        if answer == 'y'
          new_game = WheelOfFortune.new
          new_game.player.name = player.name
          new_game.play
        elsif answer == 'n'
          puts "Thanks for playing, #{player.name}!"
          exit
        end
      end
      round += 1
      
    end
  end
end

start = WheelOfFortune.new
start.play
