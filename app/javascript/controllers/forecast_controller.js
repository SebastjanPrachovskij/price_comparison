// app/javascript/controllers/forecast_controller.js
import { Controller } from "@hotwired/stimulus";
import Chartkick from "chartkick";

export default class extends Controller {
  static values = { url: String }

  updateGraph(event) {
    event.preventDefault();
    const url = this.urlValue;
  
    fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
      .then(response => response.json())
      .then(data => {
        console.log("Combined data received:", data);
        new Chartkick.LineChart("price_chart", [
          {name: "Historical", data: data.historical, color: "#3366CC"},
          {name: "Forecast", data: data.forecast, color: "#D9534F"}
        ], {refresh: true});
      })
      .catch(error => console.error('Error fetching data:', error));
  }  
}
