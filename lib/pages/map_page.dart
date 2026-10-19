import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> 
  with AutomaticKeepAliveClientMixin{
  final MapController mapController = MapController();
  final TextEditingController searchController =
      TextEditingController();

  LatLng currentPosition = const LatLng(5.3600, -4.0083);

  bool loading = false;
  DateTime? lastRequest;

  List<Marker> markers = [];

  List<Map<String, dynamic>> etablissements = [];
  List<Map<String, dynamic>> etablissementsFiltres = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // 🌍 GOOGLE MAPS
  Future<void> openGoogleMaps(
    double lat,
    double lon,
  ) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon",
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Erreur Maps : $e");
    }
  }

  // 📍 LOCALISATION UTILISATEUR
  Future<void> getLocation() async {
    setState(() => loading = true);

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() => loading = false);
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      setState(() => loading = false);
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    mapController.move(
      currentPosition,
      15,
    );

    await searchNearby();

    setState(() => loading = false);
  }

  // 🔎 RECHERCHE HÔPITAUX / PHARMACIES
  Future<void> searchNearby() async {
    final now = DateTime.now();

    if (lastRequest != null &&
        now.difference(lastRequest!) <
            const Duration(seconds: 5)) {
      return;
    }

    lastRequest = now;

    setState(() {
      loading = true;
      markers.clear();
      etablissements.clear();
      etablissementsFiltres.clear();
    });

    final query = """
[out:json];
(
 node["amenity"~"hospital|clinic|doctors|pharmacy"](around:4000,${currentPosition.latitude},${currentPosition.longitude});
 way["amenity"~"hospital|clinic|doctors|pharmacy"](around:4000,${currentPosition.latitude},${currentPosition.longitude});

 node["healthcare"~"hospital|clinic|doctor|pharmacy"](around:4000,${currentPosition.latitude},${currentPosition.longitude});
 way["healthcare"~"hospital|clinic|doctor|pharmacy"](around:4000,${currentPosition.latitude},${currentPosition.longitude});
);
out center;
""";

    try {
      final response = await http.post(
        Uri.parse(
          "https://overpass-api.de/api/interpreter",
        ),
        headers: {
          "User-Agent":
              "AkwabaHealthApp/1.0",
        },
        body: {
          "data": query,
        },
      );

      final data = jsonDecode(response.body);

      final elements =
          data["elements"] ?? [];

      List<Marker> nouveauxMarkers = [];

      // 📍 POSITION UTILISATEUR
      nouveauxMarkers.add(
        Marker(
          point: currentPosition,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      );

      for (var place in elements) {
        final lat =
            place["lat"] ??
                place["center"]?["lat"];

        final lon =
            place["lon"] ??
                place["center"]?["lon"];

        if (lat == null || lon == null) continue;

        final tags =
            place["tags"] ?? {};

        final name =
            tags["name"] ?? "Sans nom";

        final amenity =
            tags["amenity"] ?? "";

        final healthcare =
            tags["healthcare"] ?? "";

        IconData icon =
            Icons.local_hospital;

        Color color = Colors.red;

        String type =
            "Établissement de santé";

        if (amenity == "pharmacy" ||
            healthcare == "pharmacy") {
          icon =
              Icons.local_pharmacy;
          color = Colors.green;
          type = "Pharmacie";
        } else if (amenity ==
                "clinic" ||
            healthcare ==
                "clinic" ||
            amenity == "doctors") {
          icon =
              Icons.medical_services;
          color = Colors.orange;
          type = "Clinique";
        } else {
          icon =
              Icons.local_hospital;
          color = Colors.red;
          type = "Hôpital";
        }

        etablissements.add({
          "nom": name,
          "lat": lat,
          "lon": lon,
          "icon": icon,
          "color": color,
          "type": type,
          "position":
              LatLng(lat, lon),
        });

        nouveauxMarkers.add(
          Marker(
            point: LatLng(
              lat,
              lon,
            ),
            width: 45,
            height: 45,
            child: GestureDetector(
              onTap: () =>
                  showPlaceInfo(
                name,
                lat,
                lon,
                icon,
                color,
                type,
              ),
              child: Container(
                decoration:
                    BoxDecoration(
                  color: color,
                  shape:
                      BoxShape.circle,
                  border:
                      Border.all(
                    color:
                        Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      }

      setState(() {
        markers = nouveauxMarkers;
        etablissementsFiltres =
            List.from(
          etablissements,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text("Erreur : $e"),
          ),
        );
      }
    } finally {
      setState(
          () => loading = false);
    }
  }
  // 🔎 RECHERCHE DANS L'APPBAR
void filtrerEtablissements(String valeur) {
  setState(() {
    etablissementsFiltres = etablissements.where((e) {
      return e["nom"]
          .toString()
          .toLowerCase()
          .contains(valeur.toLowerCase());
    }).toList();
  });

  if (etablissementsFiltres.isNotEmpty) {
    mapController.move(
      etablissementsFiltres.first["position"],
      16,
    );
  }
}

// 📄 FICHE ÉTABLISSEMENT
void showPlaceInfo(
  String nom,
  double lat,
  double lon,
  IconData icon,
  Color color,
  String type,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (_) {
      return Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 50,
            ),
            const SizedBox(
                height: 12),

            Text(
              nom,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 8),

            Text(
              type,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
                height: 20),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                      context);

                  openGoogleMaps(
                    lat,
                    lon,
                  );
                },
                icon: const Icon(
                  Icons.navigation,
                  color:
                      Colors.white,
                ),
                label: const Text(
                  "Ouvrir l'itinéraire",
                  style:
                      TextStyle(
                    color: Colors.white,
                  ),
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.green
                          .shade800,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  super.build(context);
  
  return Scaffold(
    appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.transparent,

  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF6EEB83),
           Color.fromARGB(255, 243, 190, 94),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),

  title: TextField(
    controller: searchController,
    style: const TextStyle(
      color: Colors.white,
    ),
    decoration: InputDecoration(
      hintText: "Rechercher...",
      hintStyle: const TextStyle(
        color: Colors.white60,
      ),
      prefixIcon: const Icon(
        Icons.search,
        color: Colors.white,
      ),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    onChanged: filtrerEtablissements,
  ),

  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
),

    body: Stack(
      children: [
        FlutterMap(
          mapController:
              mapController,
          options: MapOptions(
            initialCenter:
                currentPosition,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName:
                  "akwaba.health.app",
            ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),

        if (loading)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets
                        .all(12),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                              20),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                      ),
                    ),
                    SizedBox(
                        width: 10),
                    Text(
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      "Recherche pharmacies et hôpitaux..."),
                  ],
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 140,
            child:
                ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.all(12),
              itemCount:
                  etablissementsFiltres.length,
              itemBuilder:
                  (context,
                      index) {
                final e =
                    etablissementsFiltres[index];
                return GestureDetector(
                  onTap: () {
                    mapController
                        .move(
                      e["position"],
                      16,
                    );
                  },
                  child:
                      Container(
                    width: 170,
                    margin:
                        const EdgeInsets.only(
                      right: 10,
                    ),
                    padding:
                        const EdgeInsets.all(12),
                    decoration:
                        BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          e["icon"],
                          color: e["color"],
                          size: 28,
                        ),

                        const SizedBox(height: 6),

                        Flexible(
                          child: Text(
                            e["nom"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          e["type"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Positioned(
          right: 16,
          bottom: 140,
          child: FloatingActionButton(
            heroTag: "gps",
            backgroundColor:
                Colors.white,
            onPressed:
                getLocation,
            child: Icon(
              Icons.my_location,
              color: const Color.fromARGB(255, 132, 236, 138),
            ),
          ),
        ),

        Positioned(
          right: 16,
          bottom: 210,
          child: FloatingActionButton(
            heroTag: "search",
            backgroundColor:
                Colors.white,
            onPressed:
                searchNearby,
            child: Icon(
              Icons.local_hospital,
              color: const Color.fromARGB(255, 132, 236, 138),
            ),
          ),
        ),
      ],
    ),
  );
}
}