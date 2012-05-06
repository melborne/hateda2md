class String
  def ~
    mergin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{mergin}}/, '')
  end

  def to_nil
    self.empty? ? nil : self
  end
end
