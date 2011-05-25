module SourcesHelper
  # Return HTML with a link to the the external source URL.
  def source_url_link(source)
    return link_to strip_tags(source.url), strip_tags(source.url), { :rel => "nofollow", :target => "_BLANK" }
  end
end
