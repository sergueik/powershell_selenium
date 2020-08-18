# based on: http://forum.oszone.net/thread-346030.html
# see also: https://developers.google.com/youtube/v3/docs/videos#methods
# https://developers.google.com/youtube/v3/quickstart/java
# https://github.com/ferisystem/YouTube-Extractors
# NOTE: the get_video_info isn't a documented YouTube API
param (
  [String]$youtube_video_id = 'v1IFF--TT-I',
  [switch]$debug
)

$saved = $Debugpreference
if ($debug) {
  $Debugpreference = 'Continue'
}
add-type -AssemblyName 'System.Web'
$query_string = "https://www.youtube.com/get_video_info?video_id=${youtube_video_id}"
write-debug $query_string
$page = Invoke-WebRequest $query_string
# write-debug $page
$data = ConvertFrom-Json -inputobject ([System.Web.HttpUtility]::ParseQueryString($page).Get('player_response'))
if ($debug) {
  format-list -inputobject $data
}
$videodetails = $data.videoDetails
if ($debug) {
  format-list -inputobject $videodetails
}
write-output $data.videoDetails.title
write-output $data.videoDetails.videoId

$Debugpreference = $saved
