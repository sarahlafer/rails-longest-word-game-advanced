require "open-uri"

class GamesController < ApplicationController
  VOWELS = %w(A E I O U Y)

  def new
    @letters = ('A'..'Z').to_a.sample(9)
    session[:grid] = @letters
    session[:start_time] = Time.now
  end

  def score
    @end_time = Time.now
    @letters = params[:letters].split
    @word = (params[:word] || "").upcase
    @included = included?(@word, @letters)
    @english_word = english_word?(@word)
    @time = (@end_time - Time.parse(session[:start_time])).round(2)
    @score = score_and_message(@word, @letters, @time)
  end

  private

  def included?(word, letters)
    word.chars.all? { |letter| word.count(letter) <= letters.count(letter) }
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time).round(2)
      # [score, "well done"]
      "Your score is #{score}"
    end
  end
end
