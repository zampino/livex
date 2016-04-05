import Channels from "./channels"
const elmDiv = document.querySelector("#elm-container");
const elmApp = Elm.embed(Elm.Main, elmDiv, {
  circleEvents: ["c1", "omega", 0.1],
  penEvents: 1.0,
  cleanEvents: 0.0,
  modeEvents: 0.0
});
// window.ports = elmApp.ports
let channels = new Channels(elmApp.ports)
channels.connect()
