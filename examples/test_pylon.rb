client = Pylon::Client.new(
  api_key: ENV.fetch("PYLON_API_KEY", nil),
  debug: false
) # Temporarily enable debug to see response structure