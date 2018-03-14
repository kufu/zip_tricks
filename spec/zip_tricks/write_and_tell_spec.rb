require_relative '../spec_helper'

describe ZipTricks::WriteAndTell do
  it 'maintains the count of bytes written' do
    adapter = described_class.new('')
    expect(adapter.tell).to be_zero

    adapter << 'hello'
    adapter << ''
    adapter << '!'
    expect(adapter.tell).to eq(6)
  end

  it 'is able to write frozen String objects in different encodings, converting them to binary' do
    strs = [
      [12, 123, 0, 3].pack('C*'),
      'текста кусок',
      'текста замороженный кусок'.freeze,
      [12, 123, 0, 3].pack('C*')
    ]

    buf = 'превед'.force_encoding(Encoding::BINARY)
    writer = described_class.new(buf)
    strs.each { |s| writer << s }
    expect(writer.tell).to eq(79)
    expect(buf.bytesize).to eq(91) # It already contained some bytes
  end

  it 'is able to write into a null writer or a blackhole maintaining offsets' do
    writer = described_class.new(ZipTricks::NullWriter)
    writer << 'Hello'
    writer << 'Goodbye'
    writer << 'What a day!'
    writer.advance_position_by(10)
    expect(writer.tell).to eq(33)
  end

  it 'advances the internal pointer using advance_position_by' do
    str = ''

    adapter = described_class.new(str)
    expect(adapter.tell).to be_zero

    adapter << 'hello'
    adapter << ''
    adapter << '!'
    expect(adapter.tell).to eq(6)
    adapter.advance_position_by(128_981)
    expect(adapter.tell).to eq(6 + 128_981)
    expect(str).to eq('hello!')
  end
end
