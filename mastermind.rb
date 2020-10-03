# frozen_string_literal: false
#require 'pry'
class Player

  def initialize
    @score = 0
  end

end

class Codemaker < Player
  attr_reader :code
  def initialize(colors) # create a code upon initialization
    @code = []
    until @code.length == 4
      idx = rand(colors.length)
      @code.push(colors[idx])
    end
  end
  
  def change_code(colors)
    @code = colors.shuffle[0..3]
  end

  def check(answer)
    m = 0
    n = 0
    code_copy = @code[0..3]
    ans_copy = answer[0..3]
  
    for i in 0..3 # check for correct colors in correct positions
      if answer[i] == @code[i]
        #binding.pry
        n += 1
        code_copy.delete_at(code_copy.find_index(answer[i]))
        ans_copy.delete_at(ans_copy.find_index(answer[i]))
      end
    end

    for i in 0...ans_copy.length # check for correct colors in wrong positions
      if code_copy.include?(ans_copy[i]) # check code_copy for single occurences of each color
        m += 1
        code_copy.delete_at(code_copy.find_index(ans_copy[i])) # delete just one element that corresponds with the color
      end
    end
  return [m, n] # m - correct colors in wrong position, n - correct position and color
  end

end

class Codebreaker < Player

  def guess (colors)
    puts "Pick four colors from #{colors}. Write your answer in order separated by newlines:"
    answer = []
    
    until answer.length == 4
      ans = nil
      until Mastermind::COLORS.include?(ans) #check if user passes an acceptable choice
        ans = gets.chomp
        unless Mastermind::COLORS.include?(ans)
          puts 'Your answer is not among the choices!'
        end
      end
      answer.push(ans)
    end
    return answer
  end

end


class Mastermind

  COLORS = ['blk', 'wht', 'red', 'grn', 'blu', 'yel']
  ROUNDS = 12

  def game (codemaker, codebreaker)

    rounds_taken = 0
    clue = [0, 0]
    until clue[1] == 4 || rounds_taken == ROUNDS
      puts "Guess No.#{rounds_taken + 1}"
      ans = codebreaker.guess(COLORS)
      clue = codemaker.check(ans)
      puts "You have #{clue[0]} correctly colored pins in the wrong position, and #{clue[1]} in the correct position."
      rounds_taken += 1
    end

    puts "Game over. The code is #{codemaker.code}."
    
    puts winner(clue[1], rounds_taken, codebreaker) 
    
  end

  def winner (red_pins, rounds_taken, codebreaker)
    if red_pins == 4
      codebreaker.score += 1
      return "Codebreaker wins after #{rounds_taken} rounds!"
    elsif red_pins < 4 && rounds_taken == ROUNDS
      codebreaker.losses += 1
      return 'Codemaker wins!'
    else
      return 'What just happened?'
    end
  end

end

# main

# game loop
play_again = 'Yes'
codemaker = Codemaker.new(Mastermind::COLORS)
codebreaker = Codebreaker.new
until play_again == 'No'
  new_game = Mastermind.new

  # prompt player for change of roles
  # if yes
    # switch roles but retain scores
  # else
    # play game with same roles

  new_game.game(codemaker, codebreaker)

  play_again = nil

  until play_again == 'Yes' || play_again == 'No'
    puts 'Play again? Type Yes or No'
    play_again = gets.chomp
  end

end

puts "Ended game. Codebreaker's wins: #{codebreaker.score} | losses: #{codebreaker.losses}."