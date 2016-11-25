module  Hiera

  # Get the hiera configuration
  def Hiera.getSettings(config = 'config::pdfmd')
    return `hiera #{config}`
  end

  # Determine the valid setting
  # A) manual setting
  # B) Hiera setting
  # C) default setting
  def Hiera.getActiveSetting(setA, setB, setC)
    if not setA.nil?
      setA
    elsif setA.nil? and not setB.nil?
      setB
    else
      setC
    end
  end

end
