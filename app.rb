require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'json'

set :database, 'sqlite3:///member.db'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Member < ActiveRecord::Base
end

get '/' do
  @title ="Accueil"
  haml :index, :layout_engine => :erb
end

get '/members' do
  @title = "foobar"
  @members = Member.all
  erb :members
end

get '/members/new' do
  erb :new_member
end

get '/members/:id.json' do
  content_type :json
  @member = Member.find(params[:id])

  {
    id: @member.id,
    prenom: @member.prenom,
    nom: @member.nom,
    datenaiss: @member.date,
    cp:@member.cp,
    numtel:@member.tel
  }.to_json
end

get '/members/:id' do
  @member_id = params[:id]

  erb :"members/show"
end

get '/members.json' do
  content_type 'application/json'
  @title = "foobar"  
  @members = Member.all
  erb :'members.json', layout: false
end

post '/new_member' do
  Member.create({
    nom: params[:nom],
    prenom: params[:prenom],
    adresse: params[:adresse],
    email: params[:email],
    tel: params[:tel]
  })
  erb :"thanks"
end

get 'members/:member_id/destroy' do
  @member = Member.find(params[:id])
  @member.destroy
  @members = Member.all
  erb :"members/_delete_member_button"
end

# formulaire html
get '/members/:member_id/edit' do
  @member = Member.find(params[:member_id])

  erb :"/members/edit"
end

# traitement des parametres du formulaire
put '/members/:id' do
  @member = Member.find(params[:id])

  if @member.update_attributes(params[:member])
    redirect "/members/#{@member.id}"
  else
    @error_message = "Le membre n'a pas ete modifie."

    erb :"/members/edit"
  end
end
