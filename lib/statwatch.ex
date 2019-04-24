defmodule Statwatch do
  def run do
    fetch_stats() |> save_csv
  end
  def column_names() do
    Enum.join ~w(DateTime Subscribers Videos Views), ","
  end

  def fetch_stats() do
    now = DateTime.to_string(%{DateTime.utc_now | microsecond: {0, 0}})
    HTTPoison.start
    body = case HTTPoison.get(stat_url()) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
              body |> JSON.decode() |> elem(1)
            {:ok, %HTTPoison.Response{status_code: 404}} ->
              IO.puts "Not found :("
            {:error, %HTTPoison.Error{reason: reason}} ->
              IO.inspect reason
           end
    
   stats = hd(body["items"])["statistics"]
   [
     now,
     stats["subscriberCount"],
     stats["videoCount"],
     stats["viewCount"]
   ] |> Enum.join(", ")

  end

  def save_csv(row_of_stats) do
    filename = "stats.csv"
    unless File.exists? filename do
      File.write!(filename, column_names() <> "\n")
    end
    File.write!(filename, row_of_stats <> "\n", [:append])
  end

  def stat_url do
    youtube_api = "https://www.googleapis.com/youtube/v3/"
    channel = "id=" <> "UC_x5XG1OV2P6uZZ5FSM9Ttw"
    key = "key=" <> "AIzaSyD6pBZeW1TDUaCPnTjmXLZsjHL5GgVB9sg"
    "#{youtube_api}channels?#{channel}&#{key}&part=statistics"
  end
  
end
