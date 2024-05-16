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

        const minChartValue = data.min_chart_value;
        const maxChartValue = data.max_chart_value;


        new Chartkick.LineChart("price_chart", [
          {name: "Historical", data: data.historical, color: "#3366CC"},
          {name: "Forecast", data: data.forecast, color: "#D9534F"}
        ], {
          refresh: true,
          min: minChartValue * 0.95,
          max: maxChartValue * 1.05
        });
      })
      .catch(error => console.error('Error fetching data:', error));
  }  
}
