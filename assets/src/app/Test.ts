import "./Test.css";
import { Test } from "elm/Test";

Test.fullscreen({
  websocket: `ws://${window.location.host}/socket/websocket`
});
