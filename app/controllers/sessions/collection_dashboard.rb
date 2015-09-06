# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

module ExtraCollection
  def session( collections, assets, user )
    return [collections, assets] if !user

    item = StatsStore.search(
      object: 'User',
      o_id: user.id,
      key: 'dashboard',
    )
    return [collections, assets] if !item
    collections['StatsStore'] = [item]

    [collections, assets]
  end
  module_function :session
end
