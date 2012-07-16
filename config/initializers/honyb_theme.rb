if Spree::Config.instance 
  Spree::Config.set(:stylesheets => 'screen,honyb_theme')
  
  Spree::Config.searcher_class = Honyb::Search::Base
end
