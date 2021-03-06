# coding: UTF-8
class SitesController < ApplicationController
  load_and_authorize_resource

  def index
    @site_nodes = SiteNode.all.desc('sort')
    set_seo_meta("Ruby #{t("menu.sites")}")
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)
    @site.user_id = current_user.id
    if @site.save
      redirect_to(sites_path, notice: '提交成功。谢谢。')
    else
      render action: 'new'
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :desc, :url, :favorite, :site_node_id)
  end
end
