include Java

%w( JFrame JPanel JButton JLabel ).each do |name|
  include_class 'javax.swing.' + name
end

%w( BorderLayout AlphaComposite).each do |name|
  include_class 'java.awt.' + name
end

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))
require 'animator'


class FadeButton < JButton
  include java.awt.event.ActionListener
  attr_accessor :alpha
  def initialize()
    super("fade")
    @alpha = 1.0
    setOpaque(false)
    addActionListener(self)

    @btn_image = nil

    @animator = Animator.new(2500)
    @animator.add_target do |f|
      @alpha = f
      repaint()
    end
  end

  def actionPerformed(e)
    @animator.start
  end

  def paint(g)
    if @btn_image == nil ||
       @btn_image.getWidth != getWidth ||
       @btn_image.getHeight != getHeight
      @btn_image = getGraphicsConfiguration().createCompatibleImage(getWidth(), getHeight())
    end

    g_btn = @btn_image.getGraphics
    g_btn.setClip(g.getClip)
    super(g_btn)
    g_btn.dispose

    g.setComposite(AlphaComposite.getInstance(AlphaComposite::SRC_OVER, @alpha))
    g.drawImage(@btn_image, 0, 0, nil)
  end
end


p = JPanel.new
p.setLayout(BorderLayout.new)
p.add(FadeButton.new, BorderLayout::CENTER)
p.add(JLabel.new("  click!! =>  "), BorderLayout::WEST)

f = JFrame.new
f.add(p)
f.pack
f.setVisible(true)
f.setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
