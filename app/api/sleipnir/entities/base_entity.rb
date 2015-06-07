class Sleipnir::Entities::BaseEntity < Grape::Entity
  format_with(:strid) { |id| id.to_s } # ruby has no max int, 99% of other languages do
  format_with(:nanotime) { |t| t.to_i * 1000 } # javascript
  format_with(:epochtime) { |t| t.to_i } # non-javascript

  def self.expose_image(tag, as = tag)
    expose tag, as: as do |object|
      attachment = object.send(tag)
      styles = attachment.options[:styles]
      r = {}
      for style, _ in styles
        r[style] = globalize_paperclip(attachment.url(style))
      end
      r
    end
  end

private

  def globalize_paperclip(entity)
    if entity[0] == "/"
      # so dirty
      "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}#{APP_CONFIG["port"] && APP_CONFIG["port"] != 80 && ":#{APP_CONFIG["port"]}" || ""}#{entity}"
    else
      entity
    end
  end

  def api_collection_count
    options[:collection].length
  end

  def api_next_page
    return nil if options[:collection].last.nil?
    "#{options[:ENDPOINT]}?since_id=#{options[:collection].last.id}"
  end

  def api_collection
    options[:collection]
  end

  def application
    if object.application.nil?
      APP_FAKE_OAUTH
    else
      object.application
    end
  end
end
