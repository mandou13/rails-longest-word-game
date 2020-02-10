class GamesController < ApplicationController
  require 'open-uri'
  require 'json'

  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @word = params['word'].downcase
    @message = run_game(@word)
    if @message.split(' ')[0] == 'Congrats!'
      session[:score] += @word.chars.length
    else
      session[:score] += 0
    end
  end

  def checking_word_in_api(attempt)
    api_url = open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    answer = JSON.parse(api_url)
    answer['found']
  end

  def array_to_hash(attempt)
    hash = Hash.new(0)
    attempt.each { |letter| hash[letter] += 1 }
    hash
  end

  def word_in_the_grid?(attempt)
    attempt = array_to_hash(attempt.chars)
    grid = array_to_hash(params['letters'].downcase.split(' '))
    attempt.each do |key, value|
      return false if grid[key] < value
    end
    true
  end

  def run_game(attempt)
    # TODO: runs the game and return detailed hash of result
    if checking_word_in_api(attempt) == false
      message = "Sorry but #{attempt.upcase} does not seem to be a valid English Word"
    elsif word_in_the_grid?(attempt) == false
      message = "Sorry but #{attempt.upcase} can't be built out of #{params['letters']}."
    else
      message = "Congrats! #{attempt.upcase} is a valid word !"
    end
    message
  end
end
