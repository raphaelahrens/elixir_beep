defmodule Frame do
  defmodule Header do
    defstruct channel: 0,
              msgno: 0,
              more: false,
              seqno: 0,
              size: 0
    
  end
  defmodule AnsHeader do
    defstruct channel: 0,
              msgno: 0,
              more: false,
              seqno: 0,
              size: 0,
              asnno: 0
    
  end
  defmodule Msg do
    defstruct header: nil,
              payload: nil

    def create(type, channel, msgno, more, seqno, size) do
      header = %Header{channel: channel, msgno: msgno, more: more, seqno: seqno, size: size}
      %Msg{header: header}
    end
  end
  defmodule Rpy do
    defstruct header: nil,
              payload: nil

    def create(type, channel, msgno, more, seqno, size) do
      header = %Header{channel: channel, msgno: msgno, more: more, seqno: seqno, size: size}
      %Rpy{header: header}
    end
  end
  defmodule Ans do
    defstruct header: nil,
              payload: nil

    def create(type, channel, msgno, more, seqno, size, ansno) do
      header = %AnsHeader{channel: channel, msgno: msgno, more: more, seqno: seqno, size: size}
      %Ans{header: header}
    end
  end
  defmodule Err do
    defstruct header: nil,
              payload: nil

    def create(type, channel, msgno, more, seqno, size, ansno \\ 0) do
      header = %Header{channel: channel, msgno: msgno, more: more, seqno: seqno, size: size}
      %Err{header: header}
    end
  end
  
  def parse(frame) do
    [bin_header, payload_trailer] = :binary.split(frame, "\r\n", [:trim])
    header = parse_header(bin_header)

    payload_size = header.size

    << payload::bytes-size(payload_size), "END\r\n">> = payload_trailer

    IO.puts header.channel
    IO.puts payload
  end

  defp parse_int(map, key) do
    int_str = map[key]
    {number, _} = Integer.parse(int_str)
    number
  end

  defp parse_header(<<"MSG "::utf8, common::binary>>) do
    common_header = parse_common(common)
    channel = parse_int(common_header, "channel")
    msgno = parse_int(common_header, "msgno")
    more = common_header["more"] == "*"
    seqno = parse_int(common_header, "seqno")
    size = parse_int(common_header, "size")

    Msg.create(channel, msgno, more, seqno, size)
  end

  defp parse_common(common_header) do
    regex = ~r/^(?<channel>\d+) (?<msgno>\d+) (?<more>[\.\*]) (?<seqno>\d+) (?<size>\d+)$/
    Regex.named_captures(regex, common_header)
  end

  defp parse_ans_common(common_header) do
    regex = ~r/^(?<channel>\d+) (?<msgno>\d+) (?<more>[\.\*]) (?<seqno>\d+) (?<size>\d+) (?<ansno>\d+)$/
    Regex.named_captures(regex, common_header)
  end
end
