class RubyLearning < Sinatra::Base
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == 'admin' and password == 'rlearning'
  end

  not_found do
    status 404
    "not found"
  end

  get "/ping" do
    status 200
  end

  get "/fizzbuzz/:number" do
    status 200

    number = params[:number]
    if number.numeric?
      number = number.to_i

      return 'FizzBuzz' if number % 15 == 0
      return 'Buzz' if number % 5 == 0
      return 'Fizz' if number % 3 == 0
      "#{number}"
    else
      halt 400, "not a number"
    end
  end

  get "/biggest/:number" do
    number = params[:number]

    if number.numeric?
      number = params[:number].to_i
      sum = sumOfNumber(number)

      maxDivisor = 0
      for item in 2..number/2
        if number % item == 0
          if sumOfNumber(item) <= sum
          maxDivisor = item
          end
        end
      end

      status maxDivisor
      "#{maxDivisor}"
    else
      halt 400, "not a number"
    end
  end
end
