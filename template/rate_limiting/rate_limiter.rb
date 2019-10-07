require_relative './environment'


class RateLimiter
  class Limited < StandardError; end

  # this might be kind of cheating but for this test 
  # I want to use redis and its built in setx function
  # which expires keys from the redis database after a 
  # set amount of time - other approaches include 
  # creating a sliding window or redis countdown hashtable
  # myself but I decided to use this for simplicity


  # For simplicity I am assuming we can split up the 
  # rate limiting into small buckets of time and that 
  # inside each bucket of time there can only be 
  # the threshold amount of requests 


  # THIS SOLUTION MAY BE INCORRECT IF A CONSTRAINT OF 
  # THE PROBLEM IS EVERY PERIOD OF TIME MUST HAVE LESS
  # THAN THE THRESHOLD AMOUNT OF REQUESTS
  #  - the written solution would fail this because it 
  #    operates using buckets of time 

  #  - the alternative solution would require using a 
  #    queue of some sort that keeps track of all requests
  #    that were made at most one period of time prior to the
  #    current request

  def initialize(throws:)
    @redis = Redis.new(host: "localhost")
    # key used for determining user requests
    @user_key = "test_user"

    # throws allows user to choose if they want to use rate limiting
    @rate_limit_active = throws 
  end

  def limit(name, threshold:, period:)
    # TODO: we can create unique keys in the future if we want 
    # to differentiate between different users - this code 
    # create one limit for everyone using this service class
    if @rate_limit_active
      if @redis.get(@user_key)
        # we have a cache hit
        request_num = @redis.incr(@user_key)
        if request_num > threshold
          # block the user 
          raise RateLimiter::Limited
        end
      else 
        # create a new instance and have it expire after the period 
        # argument to the function is passed as seconds 
        @redis.setx(@user_key, 60*period, 1)
      end
    end 
  end
end
