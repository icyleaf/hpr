# frozen_string_literal: true

command :create do |c|
  c.syntax = 'hpr create [option] url'
  c.summary = '创建 git 仓库镜像'

  c.option '-n NAME', '--name NAME', '自定义镜像名称'
  c.option '--no-create', '不创建 gitlab 的 repository'
  c.option '--no-clone', '不克隆 git 仓库'
  c.option '-P', '--progress', '显示操作进度条'

  c.action do |args, options|
    url = args.first
    name = options.name
    create = options.create
    clone = options.clone
    progress = options.progress
  end
end
