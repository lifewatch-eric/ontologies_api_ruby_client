module LinkedData::Client
  class Analytics
    HTTP = LinkedData::Client::HTTP

    attr_accessor :onts, :date

    def self.all(params = {})
      get(:analytics)
    end

    def self.last_month
      data = self.new
      data.date = last_month = DateTime.now - 1.month
      year_num = last_month.year
      month_num = last_month.month
      analytics = get(:analytics, {year: year_num, month: month_num}).to_h
      analytics.delete(:links)
      analytics.delete(:context)
      onts = []
      analytics.keys.each do |ont|
        views = analytics[ont][:"#{year_num}"][:"#{month_num}"]
        onts << {ont: ont, views: views}
      end
      data.onts = onts
      data
    end

    private

    def self.get(path, params = {})
      path = path.to_s
      path = "/"+path unless path.start_with?("/")
      HTTP.get(path, params)
    end

  end
end