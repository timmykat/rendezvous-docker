module PicturesHelper
  def picture_credit(picture)
    picture.credit.blank? ? picture.user.full_name : picture.credit
  end
end
