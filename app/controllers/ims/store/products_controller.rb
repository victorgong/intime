# encoding: utf-8
class Ims::Store::ProductsController < Ims::Store::BaseController

  def index
    @combo = ::Combo.find(params[:combo_id]) if params[:combo_id].present?
    # @search = ::Product.es_search(per_page: params[:per_page], page: params[:page])
    # @products = @search[:data]
    @search = Ims::Product.list(request, page: params[:page], pagesize: params[:per_page] || 5)
    @products = @search["data"]["items"]
    respond_to do |format|
      format.html{}
      format.json{render "list"}
    end
  end

  def show
    @product = ::Product.es_search(id: params[:id])[:data].try(:first)
  end

  def new
    @combo_id = params[:combo_id]
    product_relation_data
  end

  def edit
    @product = Ims::Product.find(request, {id: params[:id]})["data"]
    @sizes = Tag.es_search(category_id: @product[:category_id])[:data].try(:first).try(:sizes)
    product_relation_data
  end

  def create
    @combo = ::Combo.find_by_id(params[:combo_id])
    product = Ims::Product.create(request, {
      image: params["image"],
      brand_id: params["brand_id"],
      sales_code: params["coding_id"],
      sku_code: params["sku_code"],
      price: params["price"],
      category_id: params["category_id"],
      size_str: params["size_str"],
      size_ids: params["size_ids"]
    })

    if product["isSuccessful"]
      ComboProduct.create({:remote_id => product[:data][:id], :img_url => product[:data][:image], :product_type => "2",
       :price => product[:data][:price], :combo_id => @combo.try(:id),
       :brand_name => product[:data][:brand_name], :category_name => product[:data][:category_name]})
      redirect_to new_ims_store_combo_path(:combo_id => @combo.try(:id), t: Time.now.to_i)
    else
      redirect_to new_ims_store_product_path(:combo_id => @combo.try(:id))
    end
  end

  def update
    product = Ims::Product.update(request, {
      id: params[:id],
      image: params["image"],
      brand_id: params["brand_id"],
      sales_code: params["coding_id"],
      sku_code: params["sku_code"],
      price: params["price"],
      category_id: params["category_id"],
      size_str: params["size_str"],
      size_ids: params["size_ids"]
    })
    if product["isSuccessful"]
      redirect_to ims_store_products_path
    else
      redirect_to edit_ims_store_product_path(params[:id])
    end
  end

  def tutorials
  end

  def add_to_combo
    @combo = ::Combo.find(params[:combo_id])

    product = params[:product_type] == "2" ? Ims::Product.find(request, {:id => params[:id]}) : ::Product.fetch_product(params[:id])
    ComboProduct.create({:remote_id => product[:data][:id], :img_url => product[:data][:image],
      :product_type => params[:product_type], :price => product[:data][:price], :combo_id => @combo.id,
      :brand_name => product[:data][:brand_name], :category_name => product[:data][:category_name]})

    redirect_to new_ims_store_combo_path(:combo_id => @combo.id, t: Time.now.to_i)
  end

  def search
    @combo = ::Combo.find(params[:combo_id]) if params[:combo_id].present?
    @search = ::Product.es_search(per_page: params[:per_page] || 9, page: params[:page], from_discount: params["from_discount"], to_discount: params["to_discount"], from_price: params["from_price"], to_price: params["to_price"], brand_id: params["brand_id"], keywords: params["keywords"])
    @products = @search[:data].group_by{|obj| obj["createdDate"].to_date}.values
    @brands = Brand.es_search
    respond_to do |format|
      format.html{}
      format.json{render "search_list"}
    end
  end


  protected

  def product_relation_data
    @brands = Brand.es_search
    # @categories = Ims::ProductCategory.list(request)["data"]["items"]
    @categories = Tag.es_search(per_page: 200000)[:data]
    @codings = Ims::ProductCoding.list(request)["data"]["items"]
  end

end