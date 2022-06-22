import { parseFilterObject, toContentSingleton } from './utils'

class Builder {
  constructor(callback) {
    this.options = {}
    this.callback = callback
  }

  limit(by) {
    this.options.limit = by
    return this
  }

  filter(by) {
    this.options.filter = parseFilterObject(by)
    return this
  }

  order(by) {
    this.options.order = by
    return this
  }

  language(to) {
    this.options.language = to
    return this
  }

  fields(identifiers) {
    this.options.fields = identifiers
    return this
  }

  include(identifiers) {
    this.options.include = identifiers
    return this
  }

  exclude(identifiers) {
    this.options.exclude = identifiers
    return this
  }

  preview() {
    this.options.preview = true
    return this
  }

  all(withOptions) {
    this.options = { ...this.options, ...withOptions, returnType: 'all' }
    return this.callback(this.options)
  }

  async one(withOptions) {
    this.options = { ...this.options, ...withOptions, returnType: 'one' }
    const data = await this.callback(this.options)

    return toContentSingleton(data)
  }
}

export default Builder
