# frozen_string_literal: false

module Codemakerable
  
  def auto_create_code(colors)
    code = []
    until code.length == 4
      idx = rand(colors.length)
      code.push(colors[idx])
    end
    return code
  end

  def manual_create_code(colors)
    code = []
    until code.length == 4
      puts "Input a color from #{Mastermind::COLORS} to add to your code:"
      color = gets.chomp
      until Mastermind::COLORS.include?(color)
        puts "Invalid input. Input a color from #{Mastermind::COLORS}."
        color = gets.chomp
      end
      code.push(color)
    end
    puts "Your code is #{code}"
    return code
  end

  def check(answer, code)
    m = []
    n = []
    code_copy = code[0..3] 
    ans_copy = answer[0..3]
    
    # created two for loops, the first one removes all correct answers from code_copy and ans_copy 
    # this enables checking of answers with repeat colors

    for i in 0..3 # check for correct colors in correct positions
      if answer[i] == code[i]
        n.push(i)
        code_copy.delete_at(code_copy.find_index(answer[i]))
        ans_copy.delete_at(ans_copy.find_index(answer[i]))
      end
    end

    for i in 0...ans_copy.length # check for correct colors in wrong positions
      if code_copy.include?(ans_copy[i])
        # get the pos of ans_copy[i] in ans_orig, then push it if it's not yet in n or m.
        pos = answer.find_index(ans_copy[i]) 
        checked_length = 1
        until (!n.include?(pos) && !m.include?(pos)) || checked_length == 4 # check ans_orig for pos
          pos = answer[checked_length..3].find_index(ans_copy[i]) + checked_length
          checked_length += 1
        end
        m.push(pos)
        code_copy.delete_at(code_copy.find_index(ans_copy[i])) # delete just one element that corresponds with the color
      end
    end
  return [m, n] # m - array of wrong positions, n - array of correct positions
  end

end

module Codebreakerable

  def manual_guess (colors)
    puts "Pick four colors from #{colors}. Write your answer in order separated by newlines:"
    answer = []
    
    until answer.length == 4
      ans = gets.chomp
      until colors.include?(ans) #check if user passes an acceptable choice
        puts 'Your answer is not among the choices!'
        ans = gets.chomp        
      end
      answer.push(ans)
    end
    return answer
  end

  def auto_guess (colors, clue, prev_ans)
    guess = []
    if clue[0].empty? && clue[1].empty? # clue[0] - array of prev_ans indices with correct colors in wrong position; # clue[1] - correct positions
      # generate a random [col1, col1, col2, col2]
      num = rand(5)
      guess.push(colors[num])
      guess.push(colors[num])
      guess.push(colors[num+1])
      guess.push(colors[num+1])
    else 
      
      prev_nums = [] # collect here the numbers that have been used for num below, so that they don't get overwritten
      for i in 0..3

        # fill guess with correct colors in correct positions first
        if clue[1].include?(i)
          guess[i] = prev_ans[i] 
        
        # then shift correct colors in wrong positions
        elsif clue[0].include?(i)
          # put a random color in current position
          guess[i] = colors[rand(6)] if guess[i] == nil

          # generate random number to which prev_ans[i] will be transferred
          num = rand(4)

          # num should not be in clue[1] (correct colors in correct positions) or prev_nums
          while clue[1].include?(num) || prev_nums.include?(num)
            num = rand(4)
          end
          prev_nums.push(num)
          guess[num] = prev_ans[i]

        # otherwise, just put random color
        else
          if guess[i] == nil 
            guess[i] = colors[rand(6)]
          end
        end
      end
    end
    
    return guess
  end

end


class Player
  attr_accessor :name, :score
  include Codemakerable
  include Codebreakerable

  def initialize(name)
    @name = name
    @score = 0
  end

end


class Mastermind

  COLORS = ['blk', 'wht', 'red', 'grn', 'blu', 'yel']
  ROUNDS = 12

  def comp_is_maker_game (codemaker, codebreaker)

    rounds_taken = 0
    clue = [[], []]
    code = codemaker.auto_create_code(COLORS)

    until clue[1].length == 4 || rounds_taken == ROUNDS
      puts "Guess No.#{rounds_taken + 1}"
      ans = codebreaker.manual_guess(COLORS)
      clue = codemaker.check(ans, code)
      puts "You have #{clue[0].length} correctly colored pins in the wrong position, and #{clue[1].length} in the correct position."
      rounds_taken += 1
    end

    puts "Game over. The code is #{code}."
    
    puts winner(clue[1].length, rounds_taken, codebreaker, codemaker) 
    
  end

  def human_is_maker_game (codemaker, codebreaker)
    rounds_taken = 0
    clue = [[], []]
    code = codemaker.manual_create_code(COLORS)
    ans = []

    until clue[1].length == 4 || rounds_taken == ROUNDS

      puts "Guess No.#{rounds_taken + 1}"
      ans = codebreaker.auto_guess(COLORS, clue, ans)
      puts "#{codebreaker.name}'s guess is as follows:"
      puts ans
      
      clue = codemaker.check(ans, code)
      puts "#{codebreaker.name} has #{clue[0].length} correctly colored pins in the wrong position, and #{clue[1].length} in the correct position. Press enter for the next guess."
      gets.chomp
      rounds_taken += 1
      
    end

    puts "Game over. The code is #{code}."
    
    puts winner(clue[1].length, rounds_taken, codebreaker, codemaker) 
  end

  def winner (red_pins, rounds_taken, codebreaker, codemaker)
    if red_pins == 4
      codebreaker.score += 1
      return "Codebreaker #{codebreaker.name} wins after #{rounds_taken} rounds!"
    elsif red_pins < 4 && rounds_taken == ROUNDS
      codemaker.score += 1
      return "Codemaker #{codemaker.name} wins!"
    else
      return 'What just happened?'
    end
  end

end

# main

# game loop
play_again = 'Yes'

puts 'Hello, human. Before we play a game of Mastermind, what is your name?'
name = gets.chomp
human = Player.new(name)
computer = Player.new('I,Computer')

until play_again == 'No'
  new_game = Mastermind.new

  puts 'What role would you like to play? Enter B for codeBreaker or M for codeMaker:'
  role = gets.chomp
  until ['B', 'M'].include?(role)
    puts 'Invalid input. Enter B for codeBreaker or M for codeMaker:'
    role = gets.chomp
  end
  
    if role == 'B'
      codebreaker = human
      codemaker = computer
      new_game.comp_is_maker_game(codemaker, codebreaker)
    elsif role == 'M'
      codemaker = human
      codebreaker = computer
      new_game.human_is_maker_game(codemaker, codebreaker)
    else
      puts 'For some reason, still an invalid input?'
    end
      
  puts 'Play again? Type Yes or No'
  play_again = gets.chomp
  until ['Yes', 'No'].include?(play_again)
    puts 'Invalid input. Type Yes or No'
    play_again = gets.chomp
  end

end

puts "Ended game. #{human.name}'s score: #{human.score}. #{computer.name}'s score: #{computer.score}."