# frozen_string_literal: true

require "test_helper"

describe "wa_count" do
  let(:s0) { S0.create_default! }

  it "always returns no result for has_many if no possible ones exists" do
    assert_equal [], S0.where_assoc_exists(:m1)
    assert_equal [], S0.where_assoc_not_exists(:m1)
    S1.create!(S1.test_condition_column => S0.test_condition_value_for(:m1))
    assert_equal [], S0.where_assoc_exists(:m1)
    assert_equal [], S0.where_assoc_not_exists(:m1)
  end

  it "finds a matching has_many" do
    s0.create_assoc!(:m1, :S0_m1)
    s0.create_assoc!(:m1, :S0_m1)

    assert_wa_count(2, :m1)
  end

  it "doesn't find a non matching has_many" do
    s0.create_bad_assocs!(:m1, :S0_m1)

    assert_wa_count(0, :m1)
  end

  it "finds a matching has_many through has_many" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m1.create_assoc!(:m2, :S0_m2m1, :S1_m2)
    m1.create_assoc!(:m2, :S0_m2m1, :S1_m2)

    assert_wa_count(2, :m2m1)
  end

  it "doesn't find a non matching has_many through has_many" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m1.create_bad_assocs!(:m2, :S0_m2m1, :S1_m2)

    assert_wa_count(0, :m2m1)
  end

  it "finds a matching has_many through has_many using an array for the association" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m1.create_assoc!(:m2, :S1_m2)
    m1.create_assoc!(:m2, :S1_m2)

    assert_wa_count(2, [:m1, :m2])
  end

  it "doesn't find a non matching has_many through has_many using an array for the association" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m1.create_bad_assocs!(:m2, :S1_m2)

    assert_wa_count(0, [:m1, :m2])
  end

  it "finds a matching has_many through has_many through has_many" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m2 = m1.create_assoc!(:m2, :S0_m2m1, :S1_m2)
    m2.create_assoc!(:m3, :S0_m3m2m1, :S2_m3)
    m2.create_assoc!(:m3, :S0_m3m2m1, :S2_m3)

    assert_wa_count(2, :m3m2m1)
  end

  it "doesn't find a non matching has_many through has_many through has_many" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m2 = m1.create_assoc!(:m2, :S0_m2m1, :S1_m2)
    m2.create_bad_assocs!(:m3, :S0_m3m2m1, :S2_m3)

    assert_wa_count(0, :m3m2m1)
  end

  it "finds a matching has_many through a has_many with a source that is a has_many through" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m2 = m1.create_assoc!(:m2, :S1_m2)
    m2.create_assoc!(:m3, :S0_m3m1_m3m2, :S1_m3m2, :S2_m3)
    m2.create_assoc!(:m3, :S0_m3m1_m3m2, :S1_m3m2, :S2_m3)

    assert_wa_count(2, :m3m1_m3m2)
  end

  it "doesn't find a non matching has_many through a has_many with a source that is a has_many through" do
    m1 = s0.create_assoc!(:m1, :S0_m1)
    m2 = m1.create_assoc!(:m2, :S1_m2)
    m2.create_bad_assocs!(:m3, :S0_m3m1_m3m2, :S1_m3m2, :S2_m3)

    assert_wa_count(0, :m3m1_m3m2)
  end
end