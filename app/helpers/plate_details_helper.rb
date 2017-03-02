module PlateDetailsHelper

  def median(array)
    sorted = array.sort
    len = sorted.length
    (sorted[(len-1)/2] + sorted[len / 2]) / 2
  end

end
