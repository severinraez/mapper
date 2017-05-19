class ForceCreateSentimentUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Sentiment, :uuid, force: true
  end

  def down
    drop_constraint :Sentiment, :uuid
  end
end
