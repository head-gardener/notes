# TCP

Connection is established via a 3 way handshake: syn, syn-ack, ack.

-   Client chooses an initial sequence number (ISN) and sends the packet
    to the sever with the SYN bit set to indicate it is setting the ISN.
-   Server receives SYN and if it\'s in an agreeable mood:
    -   Server chooses its own initial sequence number
    -   Server sets SYN to indicate it is choosing its ISN
    -   Server copies the (client ISN +1) to its ACK field and adds the
        ACK flag to indicate it is acknowledging receipt of the first
        packet
-   Client acknowledges the connection by sending a packet:
    -   Increases its own sequence number
    -   Increases the receiver acknowledgment number
    -   Sets ACK field
-   Data is transferred as follows:
    -   As one side sends N data bytes, it increases its SEQ by that
        number
    -   When the other side acknowledges receipt of that packet (or a
        string of packets), it sends an ACK packet with the ACK value
        equal to the last received sequence from the other
-   To close the connection:
    -   The closer sends a FIN packet
    -   The other sides ACKs the FIN packet and sends its own FIN
    -   The closer acknowledges the other side\'s FIN with an ACK

## TCP congestion control

Is used for working with connections, that drop packets. Gets
implemented via the cubic algorithm on newer operating systems and New
Reno on almost all others. Operates via a congestion window (CWND),
which is one of the factors that determine the number of bytes that can
be sent out at any time. CWND gets set to a small multiple of the
maximum segment size (MSS), and futher edited via additive
increase/multiplicative decrease approach (AIMD). Slow start describes
additive or multiplicative increase in CWND when connection is
established or recovers after a congestion.

## TCP Tuning

Adjusting values, dictating different parameters of TCP operation.
Invloves:

-   Adjusting TCP congestion control parameters.

# BGP

Border Gateway Protocol, a routing protocol run by the Internet gateway.
BGP routing table contains the list of all public IP addresses that have
been assigned by ISP\'s. Other routing protocols: RIP, OSPF.
