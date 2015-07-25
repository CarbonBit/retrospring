module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        x = super
        i = x.index '-crop'
        2.times { x.delete_at i } if i
        crop_command + x
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if @attachment.name.to_s == 'profile_picture' && target.cropping?
        ['-auto-orient', '-strip', '+repage', '-crop', "'#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}'"]
      elsif @attachment.name.to_s == 'profile_header' && target.cropping_header?
        ['-auto-orient', '-strip', '+repage', '-crop', "'#{target.crop_h_w.to_i}x#{target.crop_h_h.to_i}+#{target.crop_h_x.to_i}+#{target.crop_h_y.to_i}'"]
      end
    end

    def convert(arguments = "", local_options = {})
      # imagick shits crap out to stderr on failure but still returns 0
      arguments = arguments + ' 2>&1'
      x = Paperclip.run('convert', arguments, local_options, {swallow_stderr: false})
      throw x unless x.blank?
      x
    end
  end
end
