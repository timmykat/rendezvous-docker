module BallotsHelper
  def vote_link(ballot_id)
    link_to 'Vote', '#', 
      id: 'vote-link', 
      data: { 
        action: "", 
        voting_target: "link", 
        ballotid: ballot_id,
        turbo_frame: "categories-content" 
      }, 
      class: "btn btn-primary"
  end
end