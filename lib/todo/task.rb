# coding: utf-8

require 'active_record'

module Todo

  # Taskテーブルを表現するモデルクラス
  # @author tohrinagi
  class Task < ActiveRecord::Base
    scope :status_is, ->(status) { where( status: status ) }

    NOT_YET = 0 # タスクが完了していない

    DONE = 1 # タスクが完了した

    PENDING = 2 # 保留状態のタスク

    # ステータスの名称
    STATUS = {
      'NOT_YET' => NOT_YET,
      'DONE'    => DONE,
      'PENDING' => PENDING
    }.freeze

    validates :name,      presence: true, length: {maximum: 140 }
    validates :contents,  presence: true
    validates :status,    numericality: true, inclusion: { in: STATUS.values }
  end

end
