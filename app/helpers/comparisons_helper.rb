module ComparisonsHelper
  def prepare_chart_data(comparisons)
    data_by_gl = comparisons.each_with_object({}) do |comparison, data|
      (data[comparison.gl.upcase] ||= {})[comparison.date.strftime("%Y-%m-%d")] = comparison.average_price
    end
  
    # Convert to the expected format for Chartkick
    data_by_gl.map { |gl, data| { name: gl, data: data } }
  end
end