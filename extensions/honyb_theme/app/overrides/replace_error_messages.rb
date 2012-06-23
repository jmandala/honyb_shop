Deface::Override.new(:virtual_path => %q{shared/_error_messages},
                          :name => %q{replace_shared_error_messages},
                          :replace => %q{#errorExplanation},
                          :text => %q{
<div id="error-explanation" data-hook>
    <h2><%= t(:please_correct_the_error_listed_below, :count => target.errors.count) %>:</h2>
     <ul class="error-messages">
     <% target.errors.full_messages.each do |msg| %>
       <li><%= msg %></li>
     <% end %>
     </ul>
  </div>
}, :original => %q{<div id="errorExplanation" class="errorExplanation" data-hook>
    <h2><%= t(:errors_prohibited_this_record_from_being_saved, :count => target.errors.count) %>:</h2>
    <div><%= t(:there_were_problems_with_the_following_fields) %>:</div>
     <ul>
     <% target.errors.full_messages.each do |msg| %>
       <li><%= msg %></li>
     <% end %>
     </ul>
  </div>})
