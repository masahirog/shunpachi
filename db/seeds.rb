# 容器のシードデータ
containers = [
  '17-13',
  '19-14',
  '20-11',
  '20-15',
  '23-16',
  'MSデリカ小',
  'MSデリカ中',
  'クリアカップ',
  'バイオカップ',
  'フルーツカップ',
  '黒トレー',
  '白トレー'
]

containers.each do |name|
  Container.find_or_create_by(name: name)
end

puts "#{Container.count} containers created"