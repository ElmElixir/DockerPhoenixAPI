import Browser

main : Program () Model Msg
main =
  Browser.sandbox
  { init = init
  , update = update
  , view = view
  }