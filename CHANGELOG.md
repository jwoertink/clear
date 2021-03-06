# master/HEAD

## Breaking changes
- Migration to crystal 0.25.

## Bug fixes
- Fix #13 Calling count on paginated query
- Fix #17 and implement `group_by` method.

## Features
- SQL Builder can now be used with model collection as subqueries.
- Add methods for pagination (PR #16, thanks @jwoertink)
- Add multi-connections system (PR #18, thanks @russ)
- Add JSONB helpers
- Migrating the wiki to the sources of the project, to make easy to have PR for
  updating the documentation !

# v0.1.3alpha


## Breaking changes

- Renaming of column `column` attribute to `column_name` in `column` method helper
- Renaming of `field` by `column` in validation `Error` record
- Renaming of `Clear::Util.func` to `Clear::Util.lambda`
- `order_by` don't allow full string anymore, and will cause error in case you put string.

## Bugfixes

- Patching segfault caused by weird architecture choice of mine over the `pkey` method.
- Fix issue with delete if the primary key is not `id`
- Add watchdog to disallow inclusion of `Clear::Model` on struct objects, which
  is not intended to work.
- Issue #8: `find_or_create` and generally update without any field failed to generate good SQL.
- Issue with `belongs_to` assignment fixed.
- Fix error message when a query fail to compile, giving better insights for the developer.
- Issue #12: Fix `Collection(Model)#last`.
- Allow `fetch_columns` on last, first etc...

## Small features

- Add CHANGELOG.md file !
- `model.valid!` return itself and can be chained
- Issue #10: `scope` allow block with multiple arguments.
- Add tuple support for `in?` method in Expression Engine.

## Big features

- Creation of the Wiki manual ! Check it out !

### Polymorphism (experimental)

You can now use polymorph models with Clear !

Here for example:

```crystal

abstract class Document
  include Clear::Model

  column content : String

  self.table = "documents"

  polymorphic ImageDocument, TextDocument

  abstract def to_html : String
end

class ImageDocument < Document
  column url : String

  def to_html
    <<-HTML
      <img src='#{url}' alt='#{content}'></img>
    HTML
  end
end

class TextDocument < Document
  def to_html
    <<-HTML
      <p>#{content}</p>
    HTML
  end

end

#...

# Create a new document
ImageDocument.create({url: "http://example.com/url/to/img.jpg"})

# Use the abstract class to query !
Document.query.all.each do |document|
  puts document.to_html
end

```
