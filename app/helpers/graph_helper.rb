module GraphHelper
  
  def taxon_limits(taxon)
    <<-EOS
      <script type="text/javascript" charset="utf-8">
        var limits = {
          top: {
            "Adult Weight, g": "#{taxon.statistics.maximum_adult_weight}",
            "Birth Weight, g": "#{taxon.statistics.maximum_birth_weight}",
            "Lifespan, days":  "#{taxon.statistics.maximum_lifespan}",
            "Litter Size":     "#{taxon.statistics.maximum_litter_size}"
          },
          bottom: {
            "Adult Weight, g": "#{taxon.statistics.minimum_adult_weight}",
            "Birth Weight, g": "#{taxon.statistics.minimum_birth_weight}",
            "Lifespan, days":  "#{taxon.statistics.minimum_lifespan}",
            "Litter Size":     "#{taxon.statistics.minimum_litter_size}"
          }
        }
      </script>
    EOS
  end
  
end
