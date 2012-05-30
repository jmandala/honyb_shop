module Records
  module Po

# Recipient To City, State, Zip
    class Po34 < PoBase

      def cdf_record
        cdf = super
        cdf << recipient_city
        cdf << recipient_state
        cdf << recipient_postal_code
        cdf << recipient_country
        cdf << reserved(9)
        
        PoBase.ensure_length cdf

      end

      def recipient_city
        @order.ship_address.city.ljust_trim 25
      end

      def recipient_postal_code
        @order.ship_address.zipcode.ljust_trim 11
      end

      def recipient_state
        @order.ship_address.state.abbr.ljust_trim(3)
      end

      def recipient_country
        @order.ship_address.country.iso3
      end
    end
  end
end