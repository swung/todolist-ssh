require 'rubygems'
require 'sinatra'
require 'sequel'

configure do
	Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://data/todoes.db')
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'todo'

# taken from Rails source
class Array
  def extract_options!
	last.is_a?(::Hash) ? pop : {}
  end
end

# taken -and slightly modified- from http://sinatra.github.com/book.html#partials
helpers do
  def partial(template, *args)
	  options = args.extract_options!
	  options.merge!(:layout => false)
	  if collection = options.delete(:collection) then
	    collection.inject([]) do |buffer, member|
		  buffer << haml("_#{template}".to_sym, options.merge(
								  :layout => false, 
								  :locals => {template.to_sym => member} # :todo = <Todo:3e345>
								)
					 )
	    end.join("\n")
	  else
	    haml(template, options)
	  end
  end
end

get '/' do
  @todos = Todo.all
  @header_message = @todos.length == 0 ? "You don't have anything to do. How come?" : "Here are your todos:"
  if session['flash']
	  @flash = session['flash']
	  session['flash'] = nil
  end
  haml :index  
end

get '/new' do
  @todo = Todo.new
  haml :new
end

post '/create' do
  @todo = Todo.new(:summary => params[:summary])
  if @todo.save
	  #session['flash'] = 'todo created.'
	  #redirect '/'
  else
	  session['flash'] = 'something is wrong.'
	  haml :new
  end
end

# delete todo
delete %r{/([\d]+)} do
  # we suppose a numeric id.
  id = params[:captures].first
  Todo.get(id).destroy
  # The return value of this method
  # will be returned to a caller  
  id
end
