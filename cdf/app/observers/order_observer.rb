require_dependency "order"
require_dependency "po_file"

class OrderObserver < ActiveRecord::Observer

  def after_next_to_complete(observed, transition=nil)
    observed.save     # make sure the record is saved - otherwise, the serializer will freak out
    observed.generate_and_submit_po_file
  end

end